$videosDir = "incoming-vids";
$outputDir = "tiktok"
$desiredSplitTimeInSeconds = 60;

$videosToCut = Get-ChildItem $videosDir

function cutVideo([int]$counterForFileName, [string]$videoName, [int]$videoDuration, [string]$fullVideoPath, [int]$videoStart){
    echo "splitting video: $videoName"
    while ($videoStart -lt $videoDuration){      
      ffmpeg -ss $videoStart -t $desiredSplitTimeInSeconds -i $fullVideoPath -qscale 0 ("$outputDir\" + $videoName.replace(".mp4","") + "_{0:000}.mp4" -f $counterForFileName);
      $videoStart += $desiredSplitTimeInSeconds;
      $counterForFileName++;
    }
}

foreach ($video in $videosToCut) {    
    $videoName = $video.Name;
    if ($videoName -like '*.mp4*') {        
        $fullVideoPath ="$videosDir" + "\" + "$videoName";    
        $videoDuration = [math]::Round(((MediaInfo.exe '--Output=Video;%Duration%' $fullVideoPath) / 1000), 3)
        $videoDuration = [math]::floor($videoDuration)    
        $videoStart = 0;
        $counterForFileName = 1;        
        cutVideo $counterForFileName $videoName $videoDuration $fullVideoPath $videoStart
    }
}
