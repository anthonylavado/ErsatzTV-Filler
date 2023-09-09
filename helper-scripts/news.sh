#!/bin/bash
#V0.0.26 - Beta

echo starting news.sh

# load in configuration variables
. config-temp.conf
#test variable run yes/no
#convert variable to lowercase
if [[ ! -z "$ETV_FILLER_DOCKER" ]];
then
  output=/output
fi

if [[ -f $workdir/update-run ]];
then
processnews=no
fi

processnews1=$(echo $processnews | tr '[:upper:]' '[:lower:]')
if [[ $processnews1 = yes ]]
then
  echo news will be processed.
#news

echo selecting random audio

#audio
if [[ $audioamount = 1 ]]
then
randomNumber3=1
randomNumber4=1
randomNumber5=1
else
  randomNumber3=$(shuf -i 1-$audioamount -n 1 --repeat)
  randomNumber4=$(shuf -i 1-$audioamount -n 1 --repeat)
  randomNumber5=$(shuf -i 1-$audioamount -n 1 --repeat)
fi
audio3=$(head -n $randomNumber3 $workdir/music.txt | tail -n 1)
audio4=$(head -n $randomNumber4 $workdir/music.txt | tail -n 1)
audio5=$(head -n $randomNumber5 $workdir/music.txt | tail -n 1)


#news

echo setting background colour.

#news backgound
#background colour randomiser
if [[ $newsbackgroundcolour == random ]]
then
#awk 'BEGIN{srand()}{print rand(), $0}' $workdir/colours.txt | sort -n -k 1 | awk 'sub(/\S* /,"")'
#newsbackgroundrandomNumber=$(shuf -i 1-140 -n 1 --repeat)
#newsbackground=$(head -n $newsbackgroundrandomNumber $workdir/colours.txt | tail -n 1)
newsbackground1=White
newsbackground1=White  >> $helperdir/config-temp.conf
else
newsbackground1=$newsbackgroundcolour
newsbackground1=$newsbackgroundcolour >> $helperdir/config-temp.conf
fi

echo setting text colour.

#news text colour
if [[ $newstextcolour == random ]]
then
#awk 'BEGIN{srand()}{print rand(), $0}' $workdir/colours.txt | sort -n -k 1 | awk 'sub(/\S* /,"")'
#newstextcolourrandomNumber=$(shuf -i 1-140 -n 1 --repeat)
#newstextcolour=$(head -n $newstextcolourandomNumber $workdir/colours.txt | tail -n 1)
newstextcolour1=Black >> config-temp.conf
else
newstextcolour1=$newstextcolour  >> config-temp.conf
fi

echo writing the stylesheet.

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

echo generating the news feed

# Generate Results
  curl -s "$newsfeed" | xsltproc $newsstyle - | grep -v xml | sed 's/\&lt;p\&gt;//g' | sed 's/\&lt;\/p&\gt;//g' | sed 's/\&lt;br&\gt;//g' | man -l - | col -bx > $workdir/newstemp.txt
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
sed 's/^9 //' $workdir/news21.txt >> $workdir/news22.txt
cat $workdir/news22.txt | sed 's/\%/\\%/g' >> $workdir/news.txt

echo calculating fade duration

# Maths for fade
newsvideofadeoutstart=$(echo `expr $newsduration1 - $newsvideofadeoutduration` | bc)
newsaudiofadeoutstart=$(echo `expr $newsduration1 - $newsaudiofadeoutduration` | bc)

# Generate Video

echo generating the video

ffmpeg -y -f lavfi -i color=$newsbackground1:$videoresolution -stream_loop -1 -i "$audio3" -shortest -vf "drawtext=textfile='$workdir/news.txt': fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf: x=(w-text_w)/2:y=h-$textspeed*t: fontcolor=$newstextcolour1: fontsize=W/40:"  -pix_fmt yuv420p -c:a copy -t $newsduration $workdir/news-v1.mp4
ffmpeg -y -i $workdir/news-v1.mp4 -vf "fade=t=in:st=0:d=$newsvideofadeinduration,fade=t=out:st=$newsvideofadeoutstart:d=$newsvideofadeoutduration" -af "afade=t=in:st=0:d=$newsaudiofadeinduration,afade=t=out:st=$newsaudiofadeoutstart:d=$newsaudiofadeoutduration" $output/news-v1.mp4
touch $output/news-v1.mp4


#optional news 1

while [[ ! -z $newsfeed1 ]]; do


echo starting news-v2.

echo generating news feed.

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
sed 's/^9 //' $workdir/optional1-news21.txt >> $workdir/optional1-news22.txt
cat $workdir/optional1-news22.txt | sed 's/\%/\\%/g' >> $workdir/optional1-news.txt


echo generating the video
# Generate Video

ffmpeg -y -f lavfi -i color=$newsbackground1:$videoresolution -stream_loop -1 -i "$audio4" -shortest -vf "drawtext=textfile='$workdir/optional1-news.txt': fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf: x=(w-text_w)/2:y=h-$textspeed*t: fontcolor=$newstextcolour1: fontsize=W/40:"  -pix_fmt yuv420p -c:a copy -t $newsduration $workdir/news-v2.mp4
ffmpeg -y -i $workdir/news-v2.mp4 -vf "fade=t=in:st=0:d=$newsvideofadeinduration,fade=t=out:st=$newsvideofadeoutstart:d=$newsvideofadeoutduration" -af "afade=t=in:st=0:d=$newsaudiofadeinduration,afade=t=out:st=$newsaudiofadeoutstart:d=$newsaudiofadeoutduration" $output/news-v2.mp4
touch $output/news-v2.mp4
#set variable blank to avoid endless loop
newsfeed1=""
done
#optional news 2

while [[ ! -z $newsfeed2 ]]; do

echo starting news-v3

echo generating newsfeed

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
sed 's/^9 //' $workdir/optional2-news21.txt >> $workdir/optional2-news22.txt
cat $workdir/optional2-news22.txt | sed 's/\%/\\%/g' >> $workdir/optional2-news.txt

# Generate Video

echo generating video

ffmpeg -y -f lavfi -i color=$newsbackground1:$videoresolution -stream_loop -1 -i "$audio5" -shortest -vf "drawtext=textfile='$workdir/optional2-news.txt': fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf: x=(w-text_w)/2:y=h-$textspeed*t: fontcolor=$newstextcolour1: fontsize=W/40:"  -pix_fmt yuv420p -c:a copy -t $newsduration $wirkdir/news-v3.mp4
ffmpeg -y -i $workdir/news-v3.mp4 -vf "fade=t=in:st=0:d=$newsvideofadeinduration,fade=t=out:st=$newsvideofadeoutstart:d=$newsvideofadeoutduration" -af "afade=t=in:st=0:d=$newsaudiofadeinduration,afade=t=out:st=$newsaudiofadeoutstart:d=$newsaudiofadeoutduration" $output/news-v3.mp4
touch $output/news-v3.mp4
#set variable blank to avoid endless loop
newsfeed2=""
done
echo finished processing news feed.
echo moving to channel-offline.sh
./channel-offline.sh
else
  echo news feed will not be processed
  echo moving to channel-offline.sh
./channel-offline.sh
fi
