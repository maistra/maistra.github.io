FROM klakegg/hugo:ubuntu


RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common git ruby bundler build-essential patch ruby-dev zlib1g-dev liblzma-dev curl && \
    rm -rf /var/lib/apt/lists/*

RUN  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CC86BB64 && \
     add-apt-repository -y ppa:rmescandon/yq && \
     apt update && \
     apt install -y yq 

# Get the latest version
RUN  wget -P /tmp/ https://github.com/koalaman/shellcheck/releases/download/latest/shellcheck-latest.linux.x86_64.tar.xz && \
     tar xvf /tmp/shellcheck-latest.linux.x86_64.tar.xz -C /tmp && \
     cp /tmp/shellcheck-latest/shellcheck /usr/bin/shellcheck && \
     rm -r /tmp/shellcheck-latest.linux.x86_64.tar.xz /tmp/shellcheck-latest


RUN gem install asciidoctor && \
    gem install nokogiri && \
    gem install 'html-proofer' && \
    gem install nokogiri && gem install fastimage