<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE dictionary SYSTEM "file://localhost/System/Library/DTDs/sdef.dtd">
<dictionary>
	<suite name="Standard Suite" code="****" description="Common terms for most applications">
		<access-group identifier="*"/>
		<command name="print" code="aevtpdoc" description="Print the specified object(s)">
			<direct-parameter type="specifier" optional="yes" requires-access="r" description="list of objects to print"/>
			<parameter name="print dialog" code="pdlg" type="boolean" optional="yes" description="Should the application show the print dialog"/>
			<parameter name="with properties" code="prdt" type="print settings" optional="yes" description="the print settings"/>
			<parameter name="kind" code="pKnd" type="eKnd" optional="yes" description="the kind of printout desired"/>
			<parameter name="theme" code="pThm" type="text" optional="yes" description="name of theme to use for formatting the printout"/>
		</command>
		<command name="close" code="coreclos" description="Close an object">
			<direct-parameter type="specifier" description="the object to close"/>
		</command>
		<command name="count" code="corecnte" description="Return the number of elements of a particular class within an object">
			<direct-parameter type="specifier" requires-access="r" description="the object whose elements are to be counted"/>
			<parameter name="each" code="kocl" type="type" description="the class of the elements to be counted. Keyword 'each' is optional in AppleScript"/>
			<result type="integer" description="the number of elements"/>
		</command>
		<command name="delete" code="coredelo" description="Delete an element from an object">
			<direct-parameter type="specifier" description="the element to delete"/>
		</command>
		<command name="duplicate" code="coreclon" description="Duplicate one or more object(s)">
			<direct-parameter type="specifier" requires-access="r" description="the object(s) to duplicate"/>
			<parameter name="to" code="insh" type="location specifier" optional="yes" description="the new location for the object(s)"/>
			<result type="specifier" description="to the duplicated object(s)"/>
		</command>
		<command name="exists" code="coredoex" description="Verify if an object exists">
			<direct-parameter type="specifier" requires-access="r" description="the object in question"/>
			<result type="boolean" description="true if it exists, false if not"/>
		</command>
		<command name="make" code="corecrel" description="Make a new element">
			<parameter name="new" code="kocl" type="type" description="the class of the new element. Keyword &apos;new&apos; is optional in AppleScript"/>
			<parameter name="at" code="insh" type="location specifier" optional="yes" description="the location at which to insert the element"/>
			<parameter name="with properties" code="prdt" type="record" optional="yes" description="the initial values for the properties of the element"/>
			<result type="specifier" description="to the new object(s)"/>
		</command>
		<command name="move" code="coremove" description="Move playlist(s) to a new location">
			<direct-parameter type="playlist" requires-access="r" description="the playlist(s) to move"/>
			<parameter name="to" code="insh" type="location specifier" description="the new location for the playlist(s)"/>
		</command>
		<command name="open" code="aevtodoc" description="Open the specified object(s)">
			<direct-parameter type="specifier" description="list of objects to open"/>
		</command>
		<command name="run" code="aevtoapp" description="Run the application"/>
		<command name="quit" code="aevtquit" description="Quit the application"/>
		<command name="save" code="coresave" description="Save the specified object(s)">
			<direct-parameter type="specifier" description="the object(s) to save"/>
		</command>
		<record-type name="print settings" code="pset">
			<property name="copies" code="lwcp" type="integer" access="r" description="the number of copies of a document to be printed"/>
			<property name="collating" code="lwcl" type="boolean" access="r" description="Should printed copies be collated?"/>
			<property name="starting page" code="lwfp" type="integer" access="r" description="the first page of the document to be printed"/>
			<property name="ending page" code="lwlp" type="integer" access="r" description="the last page of the document to be printed"/>
			<property name="pages across" code="lwla" type="integer" access="r" description="number of logical pages laid across a physical page"/>
			<property name="pages down" code="lwld" type="integer" access="r" description="number of logical pages laid out down a physical page"/>
			<property name="error handling" code="lweh" type="enum" access="r" description="how errors are handled"/>
			<property name="requested print time" code="lwqt" type="date" access="r" description="the time at which the desktop printer should print the document"/>
			<property name="printer features" code="lwpf" access="r" description="printer specific options">
				<type type="text" list="yes"/>
			</property>
			<property name="fax number" code="faxn" type="text" access="r" description="for fax number"/>
			<property name="target printer" code="trpr" type="text" access="r" description="for target printer"/>
		</record-type>
		<enumeration name="eKnd" code="eKnd">
			<enumerator name="track listing" code="kTrk" description="a basic listing of tracks within a playlist"/>
			<enumerator name="album listing" code="kAlb" description="a listing of a playlist grouped by album"/>
			<enumerator name="cd insert" code="kCDi" description="a printout of the playlist for jewel case inserts"/>
		</enumeration>
		<enumeration name="enum" code="enum">
			<enumerator name="standard" code="lwst" description="Standard PostScript error handling"/>
			<enumerator name="detailed" code="lwdt" description="print a detailed report of PostScript errors"/>
		</enumeration>
	</suite>
	<suite name="Music Suite" code="hook" description="The event suite specific to Music">
		<command name="add" code="hookAdd " description="add one or more files to a playlist">
			<access-group identifier="com.apple.Music.library.read-write" access="rw"/>
			<direct-parameter description="the file(s) to add">
				<type type="file" list="yes"/>
			</direct-parameter>
			<parameter name="to" code="insh" type="location specifier" optional="yes" description="the location of the added file(s)"/>
			<result type="track" description="reference to added track(s)"/>
		</command>
		<command name="back track" code="hookBack" description="reposition to beginning of current track or go to previous track if already at start of current track">
			<access-group identifier="com.apple.Music.playback"/>
		</command>
		<command name="convert" code="hookConv" description="convert one or more files or tracks">
			<access-group identifier="com.apple.Music.library.read-write" access="rw"/>
			<direct-parameter description="the file(s)/tracks(s) to convert">
				<type type="specifier" list="yes"/>
			</direct-parameter>
			<result type="track" description="reference to converted track(s)"/>
		</command>
		<command name="download" code="hookDwnl" description="download a cloud track or playlist">
			<access-group identifier="com.apple.Music.library.read-write" access="rw"/>
			<direct-parameter type="item" description="the shared track, URL track or playlist to download"/>
		</command>
		<command name="fast forward" code="hookFast" description="skip forward in a playing track">
			<access-group identifier="com.apple.Music.playback"/>
		</command>
		<command name="next track" code="hookNext" description="advance to the next track in the current playlist">
			<access-group identifier="com.apple.Music.playback"/>
		</command>
		<command name="pause" code="hookPaus" description="pause playback">
			<access-group identifier="com.apple.Music.playback"/>
		</command>
		<command name="play" code="hookPlay" description="play the current track or the specified track or file.">
			<access-group identifier="com.apple.Music.playback"/>
			<direct-parameter type="specifier" optional="yes" requires-access="r" description="item to play"/>
			<parameter name="once" code="POne" type="boolean" optional="yes" description="If true, play this track once and then stop."/>
		</command>
		<command name="playpause" code="hookPlPs" description="toggle the playing/paused state of the current track">
			<access-group identifier="com.apple.Music.playback"/>
		</command>
		<command name="previous track" code="hookPrev" description="return to the previous track in the current playlist">
			<access-group identifier="com.apple.Music.playback"/>
		</command>
		<command name="refresh" code="hookRfrs" description="update file track information from the current information in the track’s file">
			<access-group identifier="com.apple.Music.library.read-write" access="rw"/>
			<direct-parameter type="file track" description="the file track to update"/>
		</command>
		<command name="resume" code="hookResu" description="disable fast forward/rewind and resume playback, if playing.">
			<access-group identifier="com.apple.Music.playback"/>
		</command>
		<command name="reveal" code="hookRevl" description="reveal and select a track or playlist">
			<access-group identifier="com.apple.Music.user-interface"/>
			<direct-parameter type="item" requires-access="r" description="the item to reveal"/>
		</command>
		<command name="rewind" code="hookRwnd" description="skip backwards in a playing track">
			<access-group identifier="com.apple.Music.playback"/>
		</command>
		<command name="search" code="hookSrch" description="search a playlist for tracks matching the search string. Identical to entering search text in the Search field.">
			<access-group identifier="com.apple.Music.library.read" access="r"/>
			<direct-parameter type="playlist" description="the playlist to search"/>
			<parameter name="for" code="pTrm" type="text" description="the search text"/>
			<parameter name="only" code="pAre" type="eSrA" optional="yes" description="area to search (default is all)"/>
			<result type="track" description="reference to found track(s)"/>
		</command>
		<command name="select" code="miscslct" description="select the specified object(s)">
			<access-group identifier="com.apple.Music.user-interface"/>
			<direct-parameter type="specifier" requires-access="r" description="the object(s) to select"/>
		</command>
		<command name="stop" code="hookStop" description="stop playback">
			<access-group identifier="com.apple.Music.playback"/>
		</command>
		<class name="AirPlay device" code="cAPD" description="an AirPlay device" inherits="item" plural="AirPlay devices">
			<property name="active" code="pAct" type="boolean" access="r" description="is the device currently being played to?"/>
			<property name="available" code="pAva" type="boolean" access="r" description="is the device currently available?"/>
			<property name="kind" code="pKnd" type="eAPD" access="r" description="the kind of the device"/>
			<property name="network address" code="pMAC" type="text" access="r" description="the network (MAC) address of the device"/>
			<property name="protected" code="pPro" type="boolean" access="r" description="is the device password- or passcode-protected?"/>
			<property name="selected" code="selc" type="boolean" description="is the device currently selected?"/>
			<property name="supports audio" code="pAud" type="boolean" access="r" description="does the device support audio playback?"/>
			<property name="supports video" code="pVid" type="boolean" access="r" description="does the device support video playback?"/>
			<property name="sound volume" code="pVol" type="integer" description="the output volume for the device (0 = minimum, 100 = maximum)"/>
		</class>
		<class name="application" code="capp" description="The application program">
			<cocoa class="ITNSApplication"/>
			<element type="AirPlay device">
				<access-group identifier="com.apple.Music.playback" access="rw"/>
			</element>
			<element type="browser window">
				<access-group identifier="com.apple.Music.playback" access="r"/>
				<access-group identifier="com.apple.Music.user-interface" access="rw"/>
			</element>
			<element type="encoder">
				<access-group identifier="com.apple.Music.playback" access="r"/>
			</element>
			<element type="EQ preset">
				<access-group identifier="com.apple.Music.playback" access="r"/>
			</element>
			<element type="EQ window">
				<access-group identifier="com.apple.Music.user-interface" access="rw"/>
			</element>
			<element type="miniplayer window">
				<access-group identifier="com.apple.Music.playback" access="r"/>
				<access-group identifier="com.apple.Music.user-interface" access="rw"/>
			</element>
			<element type="playlist">
				<access-group identifier="com.apple.Music.library.read" access="r"/>
				<access-group identifier="com.apple.Music.library.read-write" access="rw"/>
			</element>
			<element type="playlist window">
				<access-group identifier="com.apple.Music.playback" access="r"/>
				<access-group identifier="com.apple.Music.user-interface" access="rw"/>
			</element>
			<element type="source">
				<access-group identifier="com.apple.Music.library.read" access="r"/>
				<access-group identifier="com.apple.Music.library.read-write" access="rw"/>
			</element>
			<element type="track">
				<access-group identifier="com.apple.Music.library.read" access="r"/>
				<access-group identifier="com.apple.Music.library.read-write" access="rw"/>
			</element>
			<element type="video window">
				<access-group identifier="com.apple.Music.playback" access="r"/>
				<access-group identifier="com.apple.Music.user-interface" access="rw"/>
			</element>
			<element type="visual">
				<access-group identifier="com.apple.Music.playback" access="r"/>
			</element>
			<element type="window">
				<access-group identifier="com.apple.Music.playback" access="r"/>
				<access-group identifier="com.apple.Music.user-interface" access="rw"/>
			</element>
			<property name="AirPlay enabled" code="pAPE" type="boolean" access="r" description="is AirPlay currently enabled?">
				<access-group identifier="com.apple.Music.playback" access="r"/>
			</property>
			<property name="converting" code="pCnv" type="boolean" access="r" description="is a track currently being converted?"/>
			<property name="current AirPlay devices" code="pAPD" description="the currently selected AirPlay device(s)">
				<type type="AirPlay device" list="yes"/>
				<access-group identifier="com.apple.Music.playback" access="rw"/>
			</property>
			<property name="current encoder" code="pEnc" type="encoder" description="the currently selected encoder (MP3, AIFF, WAV, etc.)"/>
			<property name="current EQ preset" code="pEQP" type="EQ preset" description="the currently selected equalizer preset"/>
			<property name="current playlist" code="pPla" type="playlist" access="r" description="the playlist containing the currently targeted track">
				<access-group identifier="com.apple.Music.playback" access="r"/>
			</property>
			<property name="current stream title" code="pStT" type="text" access="r" description="the name of the current track in the playing stream (provided by streaming server)">
				<access-group identifier="com.apple.Music.playback" access="r"/>
			</property>
			<property name="current stream URL" code="pStU" type="text" access="r" description="the URL of the playing stream or streaming web site (provided by streaming server)">
				<access-group identifier="com.apple.Music.playback" access="r"/>
			</property>
			<property name="current track" code="pTrk" type="track" access="r" description="the current targeted track">
				<access-group identifier="com.apple.Music.playback" access="r"/>
			</property>
			<property name="current visual" code="pVis" type="visual" description="the currently selected visual plug-in"/>
			<property name="EQ enabled" code="pEQ " type="boolean" description="is the equalizer enabled?">
				<access-group identifier="com.apple.Music.playback" access="rw"/>
			</property>
			<property name="fixed indexing" code="pFix" type="boolean" description="true if all AppleScript track indices should be independent of the play order of the owning playlist."/>
			<property name="frontmost" code="pisf" type="boolean" description="is this the active application?"/>
			<property name="full screen" code="pFSc" type="boolean" description="is the application using the entire screen?"/>
			<property name="name" code="pnam" type="text" access="r" description="the name of the application"/>
			<property name="mute" code="pMut" type="boolean" description="has the sound output been muted?">
				<access-group identifier="com.apple.Music.playback" access="rw"/>
			</property>
			<property name="player position" code="pPos" type="real" description="the player’s position within the currently playing track in seconds.">
				<access-group identifier="com.apple.Music.playback" access="rw"/>
			</property>
			<property name="player state" code="pPlS" type="ePlS" access="r" description="is the player stopped, paused, or playing?">
				<access-group identifier="com.apple.Music.playback" access="rw"/>
			</property>
			<property name="selection" code="sele" type="specifier" access="r" description="the selection visible to the user">
				<access-group identifier="com.apple.Music.user-interface" access="r"/>
			</property>
			<property name="shuffle enabled" code="pShE" type="boolean" description="are songs played in random order?">
				<access-group identifier="com.apple.Music.playback" access="rw"/>
			</property>
			<property name="shuffle mode" code="pShM" type="eShM" description="the playback shuffle mode">
				<access-group identifier="com.apple.Music.playback" access="rw"/>
			</property>
			<property name="song repeat" code="pRpt" type="eRpt" description="the playback repeat mode">
				<access-group identifier="com.apple.Music.playback" access="rw"/>
			</property>
			<property name="sound volume" code="pVol" type="integer" description="the sound output volume (0 = minimum, 100 = maximum)">
				<access-group identifier="com.apple.Music.playback" access="rw"/>
			</property>
			<property name="version" code="vers" type="text" access="r" description="the version of the application">
				<access-group identifier="*"/>
			</property>
			<property name="visuals enabled" code="pVsE" type="boolean" description="are visuals currently being displayed?">
				<access-group identifier="com.apple.Music.user-interface" access="rw"/>
			</property>
		</class>
		<value-type name="double integer" code="comp" hidden="yes"/>
		<value-type name="picture" code="PICT" hidden="yes"/>
		<!-- <value-type name="raw data" code="tdta" hidden="yes"/> -->
		<class name="artwork" code="cArt" description="a piece of art within a track or playlist" inherits="item" plural="artworks">
			<access-group identifier="com.apple.Music.library.read" access="r"/>
			<access-group identifier="com.apple.Music.library.read-write" access="rw"/>
			<property name="data" code="pPCT" type="picture" description="data for this artwork, in the form of a picture"/>
			<property name="description" code="pDes" type="text" description="description of artwork as a string"/>
			<property name="downloaded" code="pDlA" type="boolean" access="r" description="was this artwork downloaded by Music?"/>
			<property name="format" code="pFmt" type="type" access="r" description="the data format for this piece of artwork"/>
			<property name="kind" code="pKnd" type="integer" description="kind or purpose of this piece of artwork"/>
			<property name="raw data" code="pRaw" type="any" description="data for this artwork, in original format"/>
		</class>
		<class name="audio CD playlist" code="cCDP" description="a playlist representing an audio CD" inherits="playlist" plural="audio CD playlists">
			<access-group identifier="com.apple.Music.library.read" access="r"/>
			<access-group identifier="com.apple.Music.library.read-write" access="rw"/>
			<element type="audio CD track"/>
			<property name="artist" code="pArt" type="text" description="the artist of the CD"/>
			<property name="compilation" code="pAnt" type="boolean" description="is this CD a compilation album?"/>
			<property name="composer" code="pCmp" type="text" description="the composer of the CD"/>
			<property name="disc count" code="pDsC" type="integer" description="the total number of discs in this CD’s album"/>
			<property name="disc number" code="pDsN" type="integer" description="the index of this CD disc in the source album"/>
			<property name="genre" code="pGen" type="text" description="the genre of the CD"/>
			<property name="year" code="pYr " type="integer" description="the year the album was recorded/released"/>
		</class>
		<class name="audio CD track" code="cCDT" description="a track on an audio CD" inherits="track" plural="audio CD tracks">
			<property name="location" code="pLoc" type="file" access="r" description="the location of the file represented by this track"/>
		</class>
		<class name="browser window" code="cBrW" description="the main window" inherits="window" plural="browser windows">
			<access-group identifier="com.apple.Music.user-interface" access="rw"/>
			<property name="selection" code="sele" type="specifier" access="r" description="the selected tracks"/>
			<property name="view" code="pPly" type="playlist" description="the playlist currently displayed in the window">
				<access-group identifier="com.apple.Music.playback" access="r"/>
			</property>
		</class>
		<class name="encoder" code="cEnc" description="converts a track to a specific file format" inherits="item" plural="encoders">
			<property name="format" code="pFmt" type="text" access="r" description="the data format created by the encoder"/>
		</class>
		<class name="EQ preset" code="cEQP" description="equalizer preset configuration" inherits="item" plural="EQ presets">
			<access-group identifier="com.apple.Music.playback" access="rw"/>
			<property name="band 1" code="pEQ1" type="real" description="the equalizer 32 Hz band level (-12.0 dB to +12.0 dB)"/>
			<property name="band 2" code="pEQ2" type="real" description="the equalizer 64 Hz band level (-12.0 dB to +12.0 dB)"/>
			<property name="band 3" code="pEQ3" type="real" description="the equalizer 125 Hz band level (-12.0 dB to +12.0 dB)"/>
			<property name="band 4" code="pEQ4" type="real" description="the equalizer 250 Hz band level (-12.0 dB to +12.0 dB)"/>
			<property name="band 5" code="pEQ5" type="real" description="the equalizer 500 Hz band level (-12.0 dB to +12.0 dB)"/>
			<property name="band 6" code="pEQ6" type="real" description="the equalizer 1 kHz band level (-12.0 dB to +12.0 dB)"/>
			<property name="band 7" code="pEQ7" type="real" description="the equalizer 2 kHz band level (-12.0 dB to +12.0 dB)"/>
			<property name="band 8" code="pEQ8" type="real" description="the equalizer 4 kHz band level (-12.0 dB to +12.0 dB)"/>
			<property name="band 9" code="pEQ9" type="real" description="the equalizer 8 kHz band level (-12.0 dB to +12.0 dB)"/>
			<property name="band 10" code="pEQ0" type="real" description="the equalizer 16 kHz band level (-12.0 dB to +12.0 dB)"/>
			<property name="modifiable" code="pMod" type="boolean" access="r" description="can this preset be modified?"/>
			<property name="preamp" code="pEQA" type="real" description="the equalizer preamp level (-12.0 dB to +12.0 dB)"/>
			<property name="update tracks" code="pUTC" type="boolean" description="should tracks which refer to this preset be updated when the preset is renamed or deleted?"/>
		</class>
		<class name="EQ window" code="cEQW" description="the equalizer window" inherits="window" plural="EQ windows">
			<access-group identifier="com.apple.Music.user-interface" access="rw"/>
		</class>
		<class name="file track" code="cFlT" description="a track representing an audio file (MP3, AIFF, etc.)" inherits="track" plural="file tracks">
			<property name="location" code="pLoc" type="file" description="the location of the file represented by this track"/>
		</class>
		<class name="folder playlist" code="cFoP" description="a folder that contains other playlists" inherits="user playlist" plural="folder playlists">
			<access-group identifier="com.apple.Music.library.read" access="r"/>
			<access-group identifier="com.apple.Music.library.read-write" access="rw"/>
		</class>
		<class name="item" code="cobj" description="an item" plural="items">
			<access-group identifier="com.apple.Music.library.read" access="r"/>
			<access-group identifier="com.apple.Music.library.read-write" access="rw"/>
			<property name="class" code="pcls" type="type" access="r" description="the class of the item"/>
			<property name="container" code="ctnr" type="specifier" access="r" description="the container of the item"/>
			<property name="id" code="ID  " type="integer" access="r" description="the id of the item"/>
			<property name="index" code="pidx" type="integer" access="r" description="the index of the item in internal application order"/>
			<property name="name" code="pnam" type="text" description="the name of the item">
				<access-group identifier="com.apple.Music.playback" access="r"/>
			</property>
			<property name="persistent ID" code="pPIS" type="text" access="r" description="the id of the item as a hexadecimal string. This id does not change over time."/>
			<property name="properties" code="pALL" type="record" description="every property of the item"/>
		</class>
		<class name="library playlist" code="cLiP" description="the master library playlist" inherits="playlist" plural="library playlists">
			<access-group identifier="com.apple.Music.library.read" access="r"/>
			<access-group identifier="com.apple.Music.library.read-write" access="rw"/>
			<element type="file track"/>
			<element type="URL track"/>
			<element type="shared track"/>
		</class>
		<class name="miniplayer window" code="cMPW" description="the miniplayer window" inherits="window" plural="miniplayer windows">
			<access-group identifier="com.apple.Music.user-interface" access="rw"/>
		</class>
		<class name="playlist" code="cPly" description="a list of tracks/streams" inherits="item" plural="playlists">
			<access-group identifier="com.apple.Music.library.read" access="r"/>
			<access-group identifier="com.apple.Music.library.read-write" access="rw"/>
			<element type="track"/>
			<element type="artwork"/>
			<property name="description" code="pDes" type="text" description="the description of the playlist"/>
			<property name="disliked" code="pHat" type="boolean" description="is this playlist disliked?"/>
			<property name="duration" code="pDur" type="integer" access="r" description="the total length of all tracks (in seconds)"/>
			<property name="name" code="pnam" type="text" description="the name of the playlist"/>
			<property name="loved" code="pLov" type="boolean" description="is this playlist loved?"/>
			<property name="parent" code="pPlP" type="playlist" access="r" description="folder which contains this playlist (if any)"/>
			<property name="size" code="pSiz" type="integer" access="r" description="the total size of all tracks (in bytes)"/>
			<property name="special kind" code="pSpK" type="eSpK" access="r" description="special playlist kind"/>
			<property name="time" code="pTim" type="text" access="r" description="the length of all tracks in MM:SS format"/>
			<property name="visible" code="pvis" type="boolean" access="r" description="is this playlist visible in the Source list?"/>
		</class>
		<class name="playlist window" code="cPlW" description="a sub-window showing a single playlist" inherits="window" plural="playlist windows">
			<access-group identifier="com.apple.Music.user-interface" access="rw"/>
			<property name="selection" code="sele" type="specifier" access="r" description="the selected tracks"/>
			<property name="view" code="pPly" type="playlist" access="r" description="the playlist displayed in the window"/>
		</class>
		<class name="radio tuner playlist" code="cRTP" description="the radio tuner playlist" inherits="playlist" plural="radio tuner playlists">
			<access-group identifier="com.apple.Music.library.read" access="r"/>
			<access-group identifier="com.apple.Music.library.read-write" access="rw"/>
			<element type="URL track"/>
		</class>
		<class name="shared track" code="cShT" description="a track residing in a shared library" inherits="track" plural="shared tracks">
			<access-group identifier="com.apple.Music.library.read" access="r"/>
			<access-group identifier="com.apple.Music.library.read-write" access="rw"/>
		</class>
		<class name="source" code="cSrc" description="a media source (library, CD, device, etc.)" inherits="item" plural="sources">
			<access-group identifier="com.apple.Music.library.read" access="r"/>
			<access-group identifier="com.apple.Music.library.read-write" access="rw"/>
			<element type="audio CD playlist"/>
			<element type="library playlist"/>
			<element type="playlist"/>
			<element type="radio tuner playlist"/>
			<element type="subscription playlist"/>
			<element type="user playlist"/>
			<property name="capacity" code="capa" type="double integer" access="r" description="the total size of the source if it has a fixed size"/>
			<property name="free space" code="frsp" type="double integer" access="r" description="the free space on the source if it has a fixed size"/>
			<property name="kind" code="pKnd" type="eSrc" access="r"/>
		</class>
		<class name="subscription playlist" code="cSuP" description="a subscription playlist from Apple Music" inherits="playlist" plural="subscription playlists">
			<access-group identifier="com.apple.Music.library.read" access="r"/>
			<element type="file track"/>
			<element type="URL track"/>
		</class>
		<class name="track" code="cTrk" description="playable audio source" inherits="item" plural="tracks">
			<access-group identifier="com.apple.Music.playback" access="r"/>
			<access-group identifier="com.apple.Music.library.read" access="r"/>
			<access-group identifier="com.apple.Music.library.read-write" access="rw"/>
			<element type="artwork"/>
			<property name="album" code="pAlb" type="text" description="the album name of the track"/>
			<property name="album artist" code="pAlA" type="text" description="the album artist of the track"/>
			<property name="album disliked" code="pAHt" type="boolean" description="is the album for this track disliked?"/>
			<property name="album loved" code="pALv" type="boolean" description="is the album for this track loved?"/>
			<property name="album rating" code="pAlR" type="integer" description="the rating of the album for this track (0 to 100)"/>
			<property name="album rating kind" code="pARk" type="eRtK" access="r" description="the rating kind of the album rating for this track"/>
			<property name="artist" code="pArt" type="text" description="the artist/source of the track"/>
			<property name="bit rate" code="pBRt" type="integer" access="r" description="the bit rate of the track (in kbps)"/>
			<property name="bookmark" code="pBkt" type="real" description="the bookmark time of the track in seconds"/>
			<property name="bookmarkable" code="pBkm" type="boolean" description="is the playback position for this track remembered?"/>
			<property name="bpm" code="pBPM" type="integer" description="the tempo of this track in beats per minute"/>
			<property name="category" code="pCat" type="text" description="the category of the track"/>
			<property name="cloud status" code="pClS" type="eClS" access="r" description="the iCloud status of the track"/>
			<property name="comment" code="pCmt" type="text" description="freeform notes about the track"/>
			<property name="compilation" code="pAnt" type="boolean" description="is this track from a compilation album?"/>
			<property name="composer" code="pCmp" type="text" description="the composer of the track"/>
			<property name="database ID" code="pDID" type="integer" access="r" description="the common, unique ID for this track. If two tracks in different playlists have the same database ID, they are sharing the same data."/>
			<property name="date added" code="pAdd" type="date" access="r" description="the date the track was added to the playlist"/>
			<property name="description" code="pDes" type="text" description="the description of the track"/>
			<property name="disc count" code="pDsC" type="integer" description="the total number of discs in the source album"/>
			<property name="disc number" code="pDsN" type="integer" description="the index of the disc containing this track on the source album"/>
			<property name="disliked" code="pHat" type="boolean" description="is this track disliked?"/>
			<property name="downloader Apple ID" code="pDAI" type="text" access="r" description="the Apple ID of the person who downloaded this track"/>
			<property name="downloader name" code="pDNm" type="text" access="r" description="the name of the person who downloaded this track"/>
			<property name="duration" code="pDur" type="real" access="r" description="the length of the track in seconds"/>
			<property name="enabled" code="enbl" type="boolean" description="is this track checked for playback?"/>
			<property name="episode ID" code="pEpD" type="text" description="the episode ID of the track"/>
			<property name="episode number" code="pEpN" type="integer" description="the episode number of the track"/>
			<property name="EQ" code="pEQp" type="text" description="the name of the EQ preset of the track"/>
			<property name="finish" code="pStp" type="real" description="the stop time of the track in seconds"/>
			<property name="gapless" code="pGpl" type="boolean" description="is this track from a gapless album?"/>
			<property name="genre" code="pGen" type="text" description="the music/audio genre (category) of the track"/>
			<property name="grouping" code="pGrp" type="text" description="the grouping (piece) of the track. Generally used to denote movements within a classical work."/>
			<property name="kind" code="pKnd" type="text" access="r" description="a text description of the track"/>
			<property name="long description" code="pLds" type="text" description="the long description of the track"/>
			<property name="loved" code="pLov" type="boolean" description="is this track loved?"/>
			<property name="lyrics" code="pLyr" type="text" description="the lyrics of the track"/>
			<property name="media kind" code="pMdK" type="eMdK" description="the media kind of the track"/>
			<property name="modification date" code="asmo" type="date" access="r" description="the modification date of the content of this track"/>
			<property name="movement" code="pMNm" type="text" description="the movement name of the track"/>
			<property name="movement count" code="pMvC" type="integer" description="the total number of movements in the work"/>
			<property name="movement number" code="pMvN" type="integer" description="the index of the movement in the work"/>
			<property name="played count" code="pPlC" type="integer" description="number of times this track has been played"/>
			<property name="played date" code="pPlD" type="date" description="the date and time this track was last played"/>
			<property name="purchaser Apple ID" code="pPAI" type="text" access="r" description="the Apple ID of the person who purchased this track"/>
			<property name="purchaser name" code="pPNm" type="text" access="r" description="the name of the person who purchased this track"/>
			<property name="rating" code="pRte" type="integer" description="the rating of this track (0 to 100)"/>
			<property name="rating kind" code="pRtk" type="eRtK" access="r" description="the rating kind of this track"/>
			<property name="release date" code="pRlD" type="date" access="r" description="the release date of this track"/>
			<property name="sample rate" code="pSRt" type="integer" access="r" description="the sample rate of the track (in Hz)"/>
			<property name="season number" code="pSeN" type="integer" description="the season number of the track"/>
			<property name="shufflable" code="pSfa" type="boolean" description="is this track included when shuffling?"/>
			<property name="skipped count" code="pSkC" type="integer" description="number of times this track has been skipped"/>
			<property name="skipped date" code="pSkD" type="date" description="the date and time this track was last skipped"/>
			<property name="show" code="pShw" type="text" description="the show name of the track"/>
			<property name="sort album" code="pSAl" type="text" description="override string to use for the track when sorting by album"/>
			<property name="sort artist" code="pSAr" type="text" description="override string to use for the track when sorting by artist"/>
			<property name="sort album artist" code="pSAA" type="text" description="override string to use for the track when sorting by album artist"/>
			<property name="sort name" code="pSNm" type="text" description="override string to use for the track when sorting by name"/>
			<property name="sort composer" code="pSCm" type="text" description="override string to use for the track when sorting by composer"/>
			<property name="sort show" code="pSSN" type="text" description="override string to use for the track when sorting by show name"/>
			<property name="size" code="pSiz" type="double integer" access="r" description="the size of the track (in bytes)"/>
			<property name="start" code="pStr" type="real" description="the start time of the track in seconds"/>
			<property name="time" code="pTim" type="text" access="r" description="the length of the track in MM:SS format"/>
			<property name="track count" code="pTrC" type="integer" description="the total number of tracks on the source album"/>
			<property name="track number" code="pTrN" type="integer" description="the index of the track on the source album"/>
			<property name="unplayed" code="pUnp" type="boolean" description="is this track unplayed?"/>
			<property name="volume adjustment" code="pAdj" type="integer" description="relative volume adjustment of the track (-100% to 100%)"/>
			<property name="work" code="pWrk" type="text" description="the work name of the track"/>
			<property name="year" code="pYr " type="integer" description="the year the track was recorded/released"/>
		</class>
		<class name="URL track" code="cURT" description="a track representing a network stream" inherits="track" plural="URL tracks">
			<access-group identifier="com.apple.Music.library.read" access="r"/>
			<access-group identifier="com.apple.Music.library.read-write" access="rw"/>
			<property name="address" code="pURL" type="text" description="the URL for this track"/>
		</class>
		<class name="user playlist" code="cUsP" description="custom playlists created by the user" inherits="playlist" plural="user playlists">
			<access-group identifier="com.apple.Music.library.read" access="r"/>
			<access-group identifier="com.apple.Music.library.read-write" access="rw"/>
			<element type="file track"/>
			<element type="URL track"/>
			<element type="shared track"/>
			<property name="shared" code="pShr" type="boolean" description="is this playlist shared?"/>
			<property name="smart" code="pSmt" type="boolean" access="r" description="is this a Smart Playlist?"/>
			<property name="genius" code="pGns" type="boolean" access="r" description="is this a Genius Playlist?"/>
		</class>
		<class name="video window" code="cNPW" description="the video window" inherits="window" plural="video windows">
			<access-group identifier="com.apple.Music.user-interface" access="rw"/>
		</class>
		<class name="visual" code="cVis" description="a visual plug-in" inherits="item" plural="visuals"/>
		<class name="window" code="cwin" description="any window" inherits="item" plural="windows">
			<access-group identifier="com.apple.Music.user-interface" access="rw"/>
			<property name="bounds" code="pbnd" type="rectangle" description="the boundary rectangle for the window"/>
			<property name="closeable" code="hclb" type="boolean" access="r" description="does the window have a close button?"/>
			<property name="collapseable" code="pWSh" type="boolean" access="r" description="does the window have a collapse button?"/>
			<property name="collapsed" code="wshd" type="boolean" description="is the window collapsed?"/>
			<property name="full screen" code="pFSc" type="boolean" description="is the window full screen?"/>
			<property name="position" code="ppos" type="point" description="the upper left position of the window"/>
			<property name="resizable" code="prsz" type="boolean" access="r" description="is the window resizable?"/>
			<property name="visible" code="pvis" type="boolean" description="is the window visible?"/>
			<property name="zoomable" code="iszm" type="boolean" access="r" description="is the window zoomable?"/>
			<property name="zoomed" code="pzum" type="boolean" description="is the window zoomed?"/>
		</class>
		<enumeration name="ePlS" code="ePlS">
			<enumerator name="stopped" code="kPSS"/>
			<enumerator name="playing" code="kPSP"/>
			<enumerator name="paused" code="kPSp"/>
			<enumerator name="fast forwarding" code="kPSF"/>
			<enumerator name="rewinding" code="kPSR"/>
		</enumeration>
		<enumeration name="eRpt" code="eRpt">
			<enumerator name="off" code="kRpO"/>
			<enumerator name="one" code="kRp1"/>
			<enumerator name="all" code="kAll"/>
		</enumeration>
		<enumeration name="eShM" code="eShM">
			<enumerator name="songs" code="kShS"/>
			<enumerator name="albums" code="kShA"/>
			<enumerator name="groupings" code="kShG"/>
		</enumeration>
		<enumeration name="eSrc" code="eSrc">
			<enumerator name="library" code="kLib"/>
			<enumerator name="audio CD" code="kACD"/>
			<enumerator name="MP3 CD" code="kMCD"/>
			<enumerator name="radio tuner" code="kTun"/>
			<enumerator name="shared library" code="kShd"/>
			<enumerator name="iTunes Store" code="kITS"/>
			<enumerator name="unknown" code="kUnk"/>
		</enumeration>
		<enumeration name="eSrA" code="eSrA">
			<enumerator name="albums" code="kSrL" description="albums only"/>
			<enumerator name="all" code="kAll" description="all text fields"/>
			<enumerator name="artists" code="kSrR" description="artists only"/>
			<enumerator name="composers" code="kSrC" description="composers only"/>
			<enumerator name="displayed" code="kSrV" description="visible text fields"/>
			<enumerator name="names" code="kSrS" description="track names only"/>
		</enumeration>
		<enumeration name="eSpK" code="eSpK">
			<enumerator name="none" code="kNon"/>
			<enumerator name="folder" code="kSpF"/>
			<enumerator name="Genius" code="kSpG"/>
			<enumerator name="Library" code="kSpL"/>
			<enumerator name="Music" code="kSpZ"/>
			<enumerator name="Purchased Music" code="kSpM"/>
		</enumeration>
		<enumeration name="eMdK" code="eMdK">
			<enumerator name="song" code="kMdS" description="music track"/>
			<enumerator name="music video" code="kVdV" description="music video track"/>
			<enumerator name="unknown" code="kUnk"/>
		</enumeration>
		<enumeration name="eRtK" code="eRtK">
			<enumerator name="user" code="kRtU" description="user-specified rating"/>
			<enumerator name="computed" code="kRtC" description="computed rating"/>
		</enumeration>
		<enumeration name="eAPD" code="eAPD">
			<enumerator name="computer" code="kAPC"/>
			<enumerator name="AirPort Express" code="kAPX"/>
			<enumerator name="Apple TV" code="kAPT"/>
			<enumerator name="AirPlay device" code="kAPO"/>
			<enumerator name="Bluetooth device" code="kAPB"/>
			<enumerator name="HomePod" code="kAPH"/>
			<enumerator name="unknown" code="kAPU"/>
		</enumeration>
		<enumeration name="eClS" code="eClS">
			<enumerator name="unknown" code="kUnk"/>
			<enumerator name="purchased" code="kPur"/>
			<enumerator name="matched" code="kMat"/>
			<enumerator name="uploaded" code="kUpl"/>
			<enumerator name="ineligible" code="kRej"/>
			<enumerator name="removed" code="kRem"/>
			<enumerator name="error" code="kErr"/>
			<enumerator name="duplicate" code="kDup"/>
			<enumerator name="subscription" code="kSub"/>
			<enumerator name="no longer available" code="kRev"/>
			<enumerator name="not uploaded" code="kUpP"/>
		</enumeration>
	</suite>
	<suite name="Internet suite" code="gurl" description="Standard terms for Internet scripting">
		<command name="open location" code="GURLGURL" description="Opens an iTunes Store or audio stream URL">
			<direct-parameter type="text" optional="yes" description="the URL to open"/>
		</command>
	</suite>
</dictionary>
