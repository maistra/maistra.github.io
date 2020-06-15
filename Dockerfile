FROM klakegg/hugo:0.72.0-ubuntu

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y locales software-properties-common curl 

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN add-apt-repository ppa:rmescandon/yq && \
    apt-get update && \
    apt-get install -y tzdata yq asciidoctor 

RUN apt-get install -y \
    ruby \
    bundler \
    nodejs \
    libmagickcore-dev \
    libmagickwand-dev

RUN (curl -LSkv https://github.com/errata-ai/vale/releases/download/v2.2.1/vale_2.2.1_Linux_64-bit.tar.gz -o /tmp/vale_2.2.1_Linux_64-bit.tar.gz) && \
    tar xzf /tmp/vale_2.2.1_Linux_64-bit.tar.gz --directory /tmp/ && \
    mv /tmp/vale /usr/bin/ && \
    rm /tmp/vale_2.2.1_Linux_64-bit.tar.gz
RUN (curl -LSkv https://github.com/koalaman/shellcheck/releases/download/v0.7.1/shellcheck-v0.7.1.linux.x86_64.tar.xz  -o /tmp/shellcheck-v0.7.1.linux.x86_64.tar.xz) && \
    tar xJf /tmp/shellcheck-v0.7.1.linux.x86_64.tar.xz --directory /tmp/ && \
    mv /tmp/shellcheck-v0.7.1/shellcheck /usr/bin/ && \
    rm -rf /tmp/shellcheck-v0.7.1.linux.x86_64.tar.xz /tmp/shellcheck-v0.7.1/

# RUN gem install stringex
# RUN gem install pygments.rb
RUN gem install nokogiri && gem install fastimage
RUN gem install html-proofer
