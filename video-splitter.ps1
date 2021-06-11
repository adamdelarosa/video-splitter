$randomColor=@('gray','red', 'blue', 'green', 'gold', 'yellow', 'orange')
$boxColor=Get-random $randomColor
$videosDir = "incoming-vids";
$outputDir = "tiktok"
$desiredSplitTimeInSeconds = 4;
#$desiredSplitTimeInSeconds = 60;

$videosToCut = Get-ChildItem $videosDir

function cutVideo([int]$counterForFileName, [string]$videoName, [int]$videoDuration, [string]$fullVideoPath, [int]$videoStart){
    echo "splitting video: $videoName"
    while ($videoStart -lt $videoDuration){      
      ffmpeg `
      -ss $videoStart `
      -t $desiredSplitTimeInSeconds `
      -i $fullVideoPath `
      -filter_complex "scale=1920:1080,
                drawtext=text='FIND ME ON YOUTUBE! PART $counterForFileName':
                x=(w-text_w)/2:                
                y=H-th-80:
                fontfile=BebasNeue-Regular.ttf:
                fontsize=50:
                fontcolor=white:                
                box=1:        
                boxcolor=$boxColor@0.5:
                boxborderw=4:" `
      -b:v 10M ("$outputDir\" + $videoName.replace(".mp4","") + " part {0:0}.mp4" -f $counterForFileName);                                                                           
      $videoStart += $desiredSplitTimeInSeconds;
      $counterForFileName++;
    }
}

foreach ($video in $videosToCut) {    
    $videoName = $video.Name;
    if ($videoName -like '*.mp4*') {        
        $fullVideoPath ="$videosDir" + "\" + "$videoName";    
        $videoDuration = [math]::Round(((mediainfo '--Output=Video;%Duration%' $fullVideoPath) / 1000), 3)
        $videoDuration = [math]::floor($videoDuration)    
        $videoStart = 0;
        $counterForFileName = 1;
        cutVideo $counterForFileName $videoName $videoDuration $fullVideoPath $videoStart
    }
}


# WATERMARK:
#
# replace this line (with watermark):
#-i watermark-tiktok.png -filter_complex "scale=1920:1080 [v1];[1:v][v1]scale2ref[wm][v1];[v1][wm]overlay=0:0,setdar=16/9" `
#
# with this line (no watermark):
#-filter_complex "scale=1920:1080" `
#       -b:v 10M ("$outputDir\" + $videoName.replace(".mp4","") + "_{0:000}.mp4" -f $counterForFileName);                                                                           
