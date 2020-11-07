
$videosDir = "incoming-vids";
$outputDir = "tiktok"
$desiredSplitTimeInSeconds = 60;

$videosToCut = Get-ChildItem $videosDir

function cutVideo([int]$counterForFileName, [string]$videoName, [int]$videoDuration, [string]$fullVideoPath, [int]$videoStart){
    echo "splitting video: $videoName"
    while ($videoStart -lt $videoDuration){      
      ffmpeg -ss $videoStart -t $desiredSplitTimeInSeconds `
      -i $fullVideoPath `
      -i watermark-tiktok.png -filter_complex "scale=1920:1080 [v1];[1:v][v1]scale2ref[wm][v1];[v1][wm]overlay=0:0,setdar=16/9" `
      -b:v 10M ("$outputDir\" + $videoName.replace(".mp4","") + "_{0:000}.mp4" -f $counterForFileName);                                                                           

      
      # ffmpeg -i $fullVideoPath -i watermark-tiktok.png -filter_complex "[0:v]setpts=PTS/1.15,crop=iw/1.2:ih/1.2,scale=1280:720 [v1];[1:v][v1]scale2ref[wm][v1];[v1][wm]overlay=0:0,setdar=16/9" "output.mp4"



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