@echo off

ffmpeg -y -i input.mkv -c:v libxvid -vf scale=704:380 -qscale:v 3 -c:a libmp3lame -b:a 192k output.avi
