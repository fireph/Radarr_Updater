#!/bin/sh

BASEPATH="/usr/local/share"
RADARRPATH="${BASEPATH}/radarr"
VERSIONFILEPATH="${RADARRPATH}/downloadurl.txt"
DOWNLOADURL=`wget -qO- "https://api.github.com/repos/Radarr/Radarr/releases?per_page=1" | jq -c | perl -MJSON::PP -E 'my @assets = @{decode_json(<STDIN>)->[0]{assets}};foreach my $a(@assets){my $url = $a->{browser_download_url};if($url =~ m/linux/){say $url;last}}'`
touch $VERSIONFILEPATH
content=$(cat $VERSIONFILEPATH)
if [ "$content" != "$DOWNLOADURL" ]; then
    echo "Updating Radarr..."
    service radarr stop
    BACKUPPATH="${RADARRPATH}_bak"
    rm -rf $BACKUPPATH
    if [ -d "$RADARRPATH" ]; then
        mv $RADARRPATH $BACKUPPATH
    fi
    wget $DOWNLOADURL -O Radarr.tar.gz
    tar -xf Radarr.tar.gz --directory $BASEPATH
    rm Radarr.tar.gz
    mv "${BASEPATH}/Radarr" $RADARRPATH
    touch $VERSIONFILEPATH
    echo $DOWNLOADURL > $VERSIONFILEPATH
    chown -R radarr:radarr $RADARRPATH
    rm -rf $BACKUPPATH
    service radarr start
fi
