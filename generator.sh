#!/bin/bash
#V0.0.6 - Beta

# load in configuration variables
. config.conf

#retrieve script location

wdir="$PWD"; [ "$PWD" = "/" ] && wdir=""
case "$0" in
  /*) scriptdir="${0}";;
  *) scriptdir="$wdir/${0#./}";;
esac
scriptdir="${scriptdir%/*}"

#set workdir

workdir=$scriptdir/workdir

#set weatherdir

weatherdir=$scriptdir/weather

#make sure workdir exists
if [ ! -d $workdir ]; then
  mkdir -p $workdir;
fi

# check variables are set. if not set default fallbacks

while [[ -z $videolength ]]; do
videolength=30
done
while [[ -z $state ]]; do
state='Texas'
done
while [[ -z $city ]]; do
city='Austin'
done
while [[ -z $newsduration ]]; do
newsduration=60
done
while [[ -z $textspeed ]]; do
textspeed=40
done
while [[ -z $videoresolution ]]; do
videoresolution=1280x720
done
while [[ -z $newsfeed ]]; do
newsfeed="https://rss.nytimes.com/services/xml/rss/nyt/World.xml"
done
while [[ -z $newstextcolour ]]; do
newstextcolour=random
done
while [[ -z $newsbackgroundcolour ]]; do
newsbackgroundcolour=random
done
while [[ -z $backgroundcolour ]]; do
backgroundcolour=random
done
while [[ -z $output ]]; do
output=~
done
while [[ -z $offlinebackgroundcolour ]]; do
offlinebackgroundcolour=random
done
while [[ -z $offlinetextcolour ]]; do
offlinetextcolour=random
done
while [[ -z $xmltv ]]; do
xmltv="http://127.0.0.1:8409/iptv/xmltv.xml"
done

#fix white spaces for curl

stateurl=$(echo $state|sed -e 's/ /%20/g')
cityurl=$(echo $city|sed -e 's/ /%20/g')

#General cleanup

rm -f $weatherdir/*
rm -r $workdir/*

#copy colours.txt
cp $scriptdir/colours.txt $workdir/colours.txt

# Audio

#select audio
#list audio files
find $scriptdir/audio -name '*.mp3' -print > $workdir/music.txt
#add number to begining of line for randomisation
awk 'BEGIN{srand()}{print rand(), $0}' $workdir/music.txt | sort -n -k 1 | awk 'sub(/\S* /,"")'

#choose random numbers
randomNumber=$(shuf -i 1-7 -n 1 --repeat)
randomNumber1=$(shuf -i 1-7 -n 1 --repeat)
randomNumber2=$(shuf -i 1-7 -n 1 --repeat)
randomNumber3=$(shuf -i 1-7 -n 1 --repeat)
randomNumber4=$(shuf -i 1-7 -n 1 --repeat)
randomNumber5=$(shuf -i 1-7 -n 1 --repeat)
audio=$(head -n $randomNumber $workdir/music.txt | tail -n 1)
audio1=$(head -n $randomNumber1 $workdir/music.txt | tail -n 1)
audio2=$(head -n $randomNumber2 $workdir/music.txt | tail -n 1)
audio3=$(head -n $randomNumber3 $workdir/music.txt | tail -n 1)
audio4=$(head -n $randomNumber4 $workdir/music.txt | tail -n 1)
audio5=$(head -n $randomNumber5 $workdir/music.txt | tail -n 1)

#End Audio

#generic Backgrounds (weather)

#background randomisation
if [[ $backgroundcolour == random ]]
then
awk 'BEGIN{srand()}{print rand(), $0}' $workdir/colours.txt | sort -n -k 1 | awk 'sub(/\S* /,"")'
backgroundrandomNumber=$(shuf -i 1-140 -n 1 --repeat)
backgroundrandomNumber1=$(shuf -i 1-140 -n 1 --repeat)
backgroundrandomNumber2=$(shuf -i 1-140 -n 1 --repeat)
background=$(head -n $backgroundrandomNumber $workdir/colours.txt | tail -n 1)
background1=$(head -n $backgroundrandomNumber1 $workdir/colours.txt | tail -n 1)
background2=$(head -n $backgroundrandomNumber2 $workdir/colours.txt | tail -n 1)
echo $background
echo $background1
else
background=$backgroundcolour
background1=$backgroundcolour
background2=$backgroundcolour
fi

# Retrieve information country code etc.
curl ipinfo.io | jq >> $workdir/information.json
country=$(jq -r '.country' $workdir/information.json)

#set weather celcius or farenheit using country code
if [[ $country == US ]]
then
weathermeasurement=?u
else
weathermeasurement=?m
fi
#weather

#retrieve weather data


curl wttr.in/${cityurl}.png$weathermeasurement --output $weatherdir/v1.png
curl v2.wttr.in/${cityurl}.png$weathermeasurement --output $weatherdir/v2.png
curl v3.wttr.in/${stateurl}.png$weathermeasurement --output $weatherdir/v3.png
wait

#make video

#ffmpeg -y -f lavfi -i color=$background:$videoresolution:d=$videolength -i $weatherdir/v1.png -stream_loop -1 -i $audio -shortest -filter_complex "[1]scale=iw*1:-1[wm];[0][wm]overlay=x=(W-w)/2:y=(H-h)/2" -pix_fmt yuv420p -c:a copy $output/weather-v1.mp4
#ffmpeg -y -f lavfi -i color=$background1:$videoresolution:d=$videolength -i $weatherdir/v2.png -stream_loop -1 -i $audio1 -shortest -filter_complex "[1]scale=iw*1:-1[wm];[0][wm]overlay=x=(W-w)/2:y=(H-h)/2" -pix_fmt yuv420p -c:a copy $output/weather-v2.mp4
#ffmpeg -y -f lavfi -i color=$background2:$videoresolution:d=$videolength -i $weatherdir/v3.png -stream_loop -1 -i $audio2 -shortest -filter_complex "[1]scale=iw*0.9:-1[wm];[0][wm]overlay=x=(W-w)/2:y=(H-h)/2" -pix_fmt yuv420p -c:a copy $output/weather-v3.mp4

#end weather


#news

#news backgound
#background colour randomiser
if [[ $newsbackgroundcolour == random ]]
then
#awk 'BEGIN{srand()}{print rand(), $0}' $workdir/colours.txt | sort -n -k 1 | awk 'sub(/\S* /,"")'
#newsbackgroundrandomNumber=$(shuf -i 1-140 -n 1 --repeat)
#newsbackground=$(head -n $newsbackgroundrandomNumber $workdir/colours.txt | tail -n 1)
newsbackground=White
else
newsbackground=$newsbackgroundcolour
fi

#news text colour
if [[ $newstextcolour == random ]]
then
#awk 'BEGIN{srand()}{print rand(), $0}' $workdir/colours.txt | sort -n -k 1 | awk 'sub(/\S* /,"")'
#newstextcolourrandomNumber=$(shuf -i 1-140 -n 1 --repeat)
#newstextcolour=$(head -n $newstextcolourandomNumber $workdir/colours.txt | tail -n 1)
newstextcolour1=Black
else
newstextcolour1=$newstextcolour
fi

# The file where we will write out the style sheet, for later use by
#  xsltprc
newsstyle="$workdir/news.xslt"

# Write the (simple) stylesheet to a convenient file -- we will edit
#  it in place later

cat << EOF > $newsstyle
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/rss/channel">
  <xsl:for-each select="item">

\fB<xsl:value-of select="title"/>\fR
.br
<xsl:value-of select="description"/>
</xsl:for-each>

</xsl:template>
</xsl:stylesheet>
EOF


# main news


# Generate Results
curl -s "$newsfeed" | xsltproc $newsstyle - | grep -v xml |  man -l - | col -bx > $workdir/newstemp.txt
#remove empty line at top of file
sed -i '1,/^$/d' $workdir/newstemp.txt
#add paragraph numbering
awk -v RS='\n\n' -vORS='\n\n' '{print NR " " $0}' $workdir/newstemp.txt > $workdir/news1.txt
# Copy first 10 arcticles
sed '/^1 /,/^\s*$/!d' $workdir/news1.txt >> $workdir/news2.txt
sed '/^2 /,/^\s*$/!d' $workdir/news1.txt >> $workdir/news2.txt
sed '/^3 /,/^\s*$/!d' $workdir/news1.txt >> $workdir/news2.txt
sed '/^4 /,/^\s*$/!d' $workdir/news1.txt >> $workdir/news2.txt
sed '/^5 /,/^\s*$/!d' $workdir/news1.txt >> $workdir/news2.txt
sed '/^6 /,/^\s*$/!d' $workdir/news1.txt >> $workdir/news2.txt
sed '/^7 /,/^\s*$/!d' $workdir/news1.txt >> $workdir/news2.txt
sed '/^8 /,/^\s*$/!d' $workdir/news1.txt >> $workdir/news2.txt
sed '/^9 /,/^\s*$/!d' $workdir/news1.txt >> $workdir/news2.txt
sed '/^10 /,/^\s*$/!d' $workdir/news1.txt >> $workdir/news2.txt
#remove paragraph numbering
sed 's/^10 //' $workdir/news2.txt >> $workdir/news12.txt
sed 's/^0 //' $workdir/news12.txt >> $workdir/news13.txt
sed 's/^1 //' $workdir/news13.txt >> $workdir/news14.txt
sed 's/^2 //' $workdir/news14.txt >> $workdir/news15.txt
sed 's/^3 //' $workdir/news15.txt >> $workdir/news16.txt
sed 's/^4 //' $workdir/news16.txt >> $workdir/news17.txt
sed 's/^5 //' $workdir/news17.txt >> $workdir/news18.txt
sed 's/^6 //' $workdir/news18.txt >> $workdir/news19.txt
sed 's/^7 //' $workdir/news19.txt >> $workdir/news20.txt
sed 's/^8 //' $workdir/news20.txt >> $workdir/news21.txt
sed 's/^9 //' $workdir/news21.txt >> $workdir/news.txt

# Generate Video

#ffmpeg -y -f lavfi -i color=$newsbackground:$videoresolution:d=$newsduration -stream_loop -1 -i $audio3 -shortest -vf "drawtext=textfile='$workdir/news.txt': fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf: x=(w-text_w)/2:y=h-$textspeed*t: fontcolor=$newstextcolour1: fontsize=W/40:"  -pix_fmt yuv420p -c:a copy $output/news-v1.mp4



#optional news 1

while [[ ! -z $newsfeed1 ]]; do





# Generate Results
curl -s "$newsfeed1" | xsltproc $newsstyle - | grep -v xml |  man -l - | col -bx > $workdir/newstemp1.txt
#remove empty line at top of file
sed -i '1,/^$/d' $workdir/newstemp1.txt
#add paragraph numbering
awk -v RS='\n\n' -vORS='\n\n' '{print NR " " $0}' $workdir/newstemp1.txt > $workdir/optional1-news1.txt
# Copy first 10 arcticles
sed '/^1 /,/^\s*$/!d' $workdir/optional1-news1.txt >> $workdir/optional1-news2.txt
sed '/^2 /,/^\s*$/!d' $workdir/optional1-news1.txt >> $workdir/optional1-news2.txt
sed '/^3 /,/^\s*$/!d' $workdir/optional1-news1.txt >> $workdir/optional1-news2.txt
sed '/^4 /,/^\s*$/!d' $workdir/optional1-news1.txt >> $workdir/optional1-news2.txt
sed '/^5 /,/^\s*$/!d' $workdir/optional1-news1.txt >> $workdir/optional1-news2.txt
sed '/^6 /,/^\s*$/!d' $workdir/optional1-news1.txt >> $workdir/optional1-news2.txt
sed '/^7 /,/^\s*$/!d' $workdir/optional1-news1.txt >> $workdir/optional1-news2.txt
sed '/^8 /,/^\s*$/!d' $workdir/optional1-news1.txt >> $workdir/optional1-news2.txt
sed '/^9 /,/^\s*$/!d' $workdir/optional1-news1.txt >> $workdir/optional1-news2.txt
sed '/^10 /,/^\s*$/!d' $workdir/optional1-news1.txt >> $workdir/optional1-news2.txt
#remove paragraph numbering
sed 's/^10 //' $workdir/optional1-news2.txt >> $workdir/optional1-news12.txt
sed 's/^0 //' $workdir/optional1-news12.txt >> $workdir/optional1-news13.txt
sed 's/^1 //' $workdir/optional1-news13.txt >> $workdir/optional1-news14.txt
sed 's/^2 //' $workdir/optional1-news14.txt >> $workdir/optional1-news15.txt
sed 's/^3 //' $workdir/optional1-news15.txt >> $workdir/optional1-news16.txt
sed 's/^4 //' $workdir/optional1-news16.txt >> $workdir/optional1-news17.txt
sed 's/^5 //' $workdir/optional1-news17.txt >> $workdir/optional1-news18.txt
sed 's/^6 //' $workdir/optional1-news18.txt >> $workdir/optional1-news19.txt
sed 's/^7 //' $workdir/optional1-news19.txt >> $workdir/optional1-news20.txt
sed 's/^8 //' $workdir/optional1-news20.txt >> $workdir/optional1-news21.txt
sed 's/^9 //' $workdir/optional1-news21.txt >> $workdir/optional1-news.txt

# Generate Video

#ffmpeg -y -f lavfi -i color=$newsbackground:$videoresolution:d=$newsduration -stream_loop -1 -i $audio4 -shortest -vf "drawtext=textfile='$workdir/optional1-news.txt': fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf: x=(w-text_w)/2:y=h-$textspeed*t: fontcolor=$newstextcolour1: fontsize=W/40:"  -pix_fmt yuv420p -c:a copy $output/news-v2.mp4
#set variable blank to avoid endless loop
newsfeed1=""
done
#optional news 2

while [[ ! -z $newsfeed2 ]]; do





# Generate Results
curl -s "$newsfeed2" | xsltproc $newsstyle - | grep -v xml |  man -l - | col -bx > $workdir/newstemp2.txt
#remove empty line at top of file
sed -i '1,/^$/d' $workdir/newstemp2.txt
#add paragraph numbering
awk -v RS='\n\n' -vORS='\n\n' '{print NR " " $0}' $workdir/newstemp2.txt > $workdir/optional2-news1.txt
# Copy first 10 arcticles
sed '/^1 /,/^\s*$/!d' $workdir/optional2-news1.txt >> $workdir/optional2-news2.txt
sed '/^2 /,/^\s*$/!d' $workdir/optional2-news1.txt >> $workdir/optional2-news2.txt
sed '/^3 /,/^\s*$/!d' $workdir/optional2-news1.txt >> $workdir/optional2-news2.txt
sed '/^4 /,/^\s*$/!d' $workdir/optional2-news1.txt >> $workdir/optional2-news2.txt
sed '/^5 /,/^\s*$/!d' $workdir/optional2-news1.txt >> $workdir/optional2-news2.txt
sed '/^6 /,/^\s*$/!d' $workdir/optional2-news1.txt >> $workdir/optional2-news2.txt
sed '/^7 /,/^\s*$/!d' $workdir/optional2-news1.txt >> $workdir/optional2-news2.txt
sed '/^8 /,/^\s*$/!d' $workdir/optional2-news1.txt >> $workdir/optional2-news2.txt
sed '/^9 /,/^\s*$/!d' $workdir/optional2-news1.txt >> $workdir/optional2-news2.txt
sed '/^10 /,/^\s*$/!d' $workdir/optional2-news1.txt >> $workdir/optional2-news2.txt
#remove paragraph numbering
sed 's/^10 //' $workdir/optional2-news2.txt >> $workdir/optional2-news12.txt
sed 's/^0 //' $workdir/optional2-news12.txt >> $workdir/optional2-news13.txt
sed 's/^1 //' $workdir/optional2-news13.txt >> $workdir/optional2-news14.txt
sed 's/^2 //' $workdir/optional2-news14.txt >> $workdir/optional2-news15.txt
sed 's/^3 //' $workdir/optional2-news15.txt >> $workdir/optional2-news16.txt
sed 's/^4 //' $workdir/optional2-news16.txt >> $workdir/optional2-news17.txt
sed 's/^5 //' $workdir/optional2-news17.txt >> $workdir/optional2-news18.txt
sed 's/^6 //' $workdir/optional2-news18.txt >> $workdir/optional2-news19.txt
sed 's/^7 //' $workdir/optional2-news19.txt >> $workdir/optional2-news20.txt
sed 's/^8 //' $workdir/optional2-news20.txt >> $workdir/optional2-news21.txt
sed 's/^9 //' $workdir/optional2-news21.txt >> $workdir/optional2-news.txt

# Generate Video

#ffmpeg -y -f lavfi -i color=$newsbackground:$videoresolution:d=$newsduration -stream_loop -1 -i $audio5 -shortest -vf "drawtext=textfile='$workdir/optional2-news.txt': fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf: x=(w-text_w)/2:y=h-$textspeed*t: fontcolor=$newstextcolour1: fontsize=W/40:"  -pix_fmt yuv420p -c:a copy $output/news-v3.mp4

#set variable blank to avoid endless loop
newsfeed2=""
done

#end news


#channel Currently offline

#make sure workdir/xmltv exists
if [ ! -d $workdir/xmltv ]; then
  mkdir -p $workdir/xmltv;
fi

if [ ! -d $output/channel-resuming ]; then
  mkdir -p $output/channel-resuming;
fi

#retrieve and split xmltv

curl $xmltv --output $workdir/xmltv.xml
tv_split --output $workdir/xmltv/%channel.xml $workdir/xmltv.xml

# List files to txt files
find $workdir/xmltv -name '*.xml' -print > $workdir/xmlfiles.txt
awk -F/ '{print $NF}' $workdir/xmlfiles.txt > $workdir/xmlfiles2.txt
cut -d "." -f 1,2 $workdir/xmlfiles2.txt > $workdir/xmlfiles3.txt
sort $workdir/xmlfiles3.txt > $workdir/xmlfiles4.txt
sed -i '/1$/ s/$/.etv/' file

#loop

#set xmltvloop variable

xmltvloop=$(head -n 1 $workdir/xmlfiles4.txt)

while [[ ! -z $xmltvloop ]]; do

#randomise audio
randomNumbernews=$(shuf -i 1-7 -n 1 --repeat)
offlineaudio=$(head -n $randomNumbernews $workdir/music.txt | tail -n 1)

# get and read xmltv data
tv_to_text --output $workdir/tempxml$xmltvloop.xml $workdir/xmltv/$xmltvloop.xml
awk '/news/{p=1}p' $workdir/tempxml$xmltvloop.xml > $workdir/xmltemp$xmltvloop.txt
awk '!/news/' $workdir/xmltemp$xmltvloop.txt > $workdir/xmltemp2$xmltvloop.xml
head -1 $workdir/xmltemp2$xmltvloop.xml > $workdir/xmltemp3$xmltvloop.txt
cut -d "-" -f 1 $workdir/xmltemp3$xmltvloop.txt > $workdir/xmltemp4$xmltvloop.txt
starttime=$(cat $workdir/xmltemp4$xmltvloop.txt)
actualstarttime=$(date --date="$starttime" +%I:%M%p)
cut -f 2 $workdir/xmltemp3$xmltvloop.txt > $workdir/xmltemp45$xmltvloop.txt
cut -d " " -f 1 $workdir/xmltemp45$xmltvloop.txt > $workdir/xmltemp5$xmltvloop.txt
nextshow=$(cat $workdir/xmltemp5$xmltvloop.txt)

offlinebackgroundcolour=$newsbackground
offlinetextcolour=$newstextcolour1

echo    This Channel is Currently offline >> $workdir/upnext$xmltvloop.txt
echo >> $workdir/upnext.txt
echo       Next showing at: $starttime >> $workdir/upnext$xmltvloop.txt
echo >> $workdir/upnext.txt
echo    Starting With: $nextshow >> $workdir/upnext$xmltvloop.txt

#ffmpeg -y -f lavfi -i color=$offlinebackgroundcolour:$videoresolution:d=5 -stream_loop -1 -i $offlineaudio -shortest -vf "drawtext=textfile='$workdir/upnext$xmltvloop.txt': fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf: x=(w-text_w)/2:y=(h-text_h)/2: fontcolor=$offlinetextcolour: fontsize=W/40:"  -pix_fmt yuv420p -c:a copy $output/channel-resuming/$xmltvloop.mp4

#awk 'NR>1' $workdir/xmlfiles4.txt > $workdir/xmllll.txt && mv $workdir/xmllll.txt $workdir/xmlfiles4.txt

#xmltvloop=$(head -n 1 $workdir/xmlfiles4.txt)
xmltvloop=""
done
