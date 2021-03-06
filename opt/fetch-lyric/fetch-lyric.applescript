-- FetchLyric
-- DESCRIPTION: 让iTunes内当前被选中的曲目自动下载并保存歌词，若歌词已存在将被忽略，支持Growl通知
-- AUTHOR: JinnLynn http:://jeeker.net
-- LAST UPDATED: 2012-05-04
-- INTRO PAGE: http://jeeker.net/fetch-lyric-for-itunes/
-- REF: Martian http://blog.4321.la/articles/2012/01/27/use-applescript-to-set-itunes-lyrics/
property scriptName : "FetchLyric"
property baseURL : "http://lyrics.sinaapp.com/"
property isGrowlRunning : false
property statusDesc : {"歌词已存在，无需再获取。", "歌词获取成功。", "歌词获取失败。", "未选择歌曲。"}
property STATUS_LYRIC_EXIST : 1
property STATUS_LYRIC_SUCCESS : 2
property STATUS_LYRIC_FAIL : 3
property STATUS_LYRIC_UNSELECTED : 4

tell application "System Events"
    set isGrowlRunning to (count of (every process whose bundle identifier is "com.Growl.GrowlHelperApp")) > 0
end tell

script growl
    on growlNotify(song_artist, song_title, status)
        if isGrowlRunning = false then return
        tell application id "com.Growl.GrowlHelperApp"
            if song_title = "" then set song_title to "unknown"
            set the_title to song_title
            if song_artist is not equal to "" then set the_title to song_artist & " - " & the_title
            set the_desc to item status of statusDesc
            set the allNotificationsList to {scriptName}
            set the enabledNotificationsList to {scriptName}
            register as application ¬
                scriptName all notifications allNotificationsList ¬
                default notifications enabledNotificationsList ¬
                icon of application "iTunes"
            notify with name ¬
                scriptName title ¬
                the_title description ¬
                the_desc application name scriptName
            -- 尝试使用歌曲封面作为Growl图标出错
        end tell
    end growlNotify
end script

tell application "iTunes"
    if selection is {} then
        tell growl to growlNotify("", "", STATUS_LYRIC_UNSELECTED)
        return
    end if
    set k to count (item of selection)
    set i to 1
    repeat
        set theTrack to (item i of selection)
        set this_artist to (get artist of theTrack)
        set this_title to (get name of theTrack)
        set this_lyric to (get lyrics of theTrack)
        -- set this_artwork to data of artwork 1 of theTrack
        
        set fetch_status to STATUS_LYRIC_FAIL
        
        if length of this_lyric < 1 then
            -- 只有当歌曲中未存在歌词时才尝试获取歌词
            set requestData to "title=" & this_title & "&artist=" & this_artist
            set songLyrics to do shell script "curl -d '" & requestData & "' " & baseURL
            if length of songLyrics > 1 then
                -- 歌词成功获取
                set lyrics of theTrack to songLyrics
                set fetch_status to STATUS_LYRIC_SUCCESS
            end if
        else
            set fetch_status to STATUS_LYRIC_EXIST
        end if
        
        tell growl to growlNotify(this_artist, this_title, fetch_status)
        
        set i to i + 1
        if i > k then exit repeat
    end repeat
    -- 如果Growl未运行则显示对话框
    if isGrowlRunning = false then
        display dialog return & "歌词获取结束！" buttons {"确定"} default button 1 with icon 1 giving up after 5 with title scriptName
    end if
end tell