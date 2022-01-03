FROM amd64/ubuntu:latest

# Original Server v436
ADD files/ut-server-linux-436.tar.gz /
# Fix for broken maps from the original file
ADD files/Patches/BrokenMapsFix.tar.gz /ut-server/
# Add the bonus packs
ADD files/UTBonusPack* /ut-server/
# Startup scripts
ADD files/Scripts/startup.sh /
ADD files/Scripts/prepare.py /
# Additonal Mutators
ADD files/Mutators/* /ut-data/
# Additonal Maps Packed
ADD files/Maps-Packed/* /ut-data/
# Maps
ADD files/Maps/* /ut-data/Maps/
Add files/UnrealTournament.ini /ut-server/System/


# Environment variables
ENV UT_SERVERURL="CTF-Face?game=BotPack.CTFGame?mutator=BotPack.InstaGibDM,MapVoteLAv2.BDBMapVote,FlagAnnouncementsV2.FlagAnnouncements"

# System prep
RUN dpkg --add-architecture i386 \
    && apt update \
    && apt install -y curl wget python3 jq libx11-6:i386\
    # lib32gcc1 lib32stdc++6 libx11-6:i386 libxext6:i386 \
    && rm -rf /var/lib/apt/lists/* \
    # Download latest OldUnreal patch
    && curl -s https://api.github.com/repos/OldUnreal/UnrealTournamentPatches/releases/latest \
    | jq -r '.assets[]|select(.browser_download_url | endswith("Linux.tar.bz2")).browser_download_url' \
    | wget -i - -O - --no-verbose --show-progress --progress=bar:force:noscroll \
    | tar -xj -C /ut-server/ \
    # Link missing file
    && ln -s /ut-server/System/libSDL-1.1.so.0 /ut-server/System/libSDL-1.2.so.0 \
    # Run initial setup
    && python3 /prepare.py i \
    && chmod +x startup.sh

VOLUME /ut-data

EXPOSE 5580/tcp 7777/udp 7778/udp 7779/udp 7780/udp 7781/udp 8777/udp 27900/tcp 27900:27900/udp

CMD ["/startup.sh"]
